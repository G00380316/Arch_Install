#!/usr/bin/env python3
import os
import gi

gi.require_version("Playerctl", "2.0")
from gi.repository import Playerctl, GLib  # noqa: E402
import argparse  # noqa: E402
import logging  # noqa: E402
import sys  # noqa: E402
import signal  # noqa: E402
import json  # noqa: E402
import pyutils.logger as logger  # noqa: E402
from pyutils.xdg_base_dirs import (  # noqa: E402
    xdg_state_home,
    xdg_cache_home,
)


logger = logger.get_logger()


#
# Global dictionary to store the track, artist, and total duration
# for each player.  Key = player_name
#
players_data = {}


def load_env_file(filepath: str) -> None:
    """
    Load environment variables from filepath.
    Each line should be in the format KEY=VALUE.
    Lines starting with '#' are ignored.
    """
    try:
        with open(filepath, encoding="utf-8") as f:
            for line in f:
                if line.strip() and not line.startswith("#"):
                    if line.startswith("export "):
                        line = line[len("export ") :]
                    key, value = line.strip().split("=", 1)
                    os.environ[key] = value.strip('"')
    except (FileNotFoundError, OSError) as e:
        logger.error(f"Error loading environment file {filepath}: {e}")


def format_time(seconds) -> str:
    """
    Convert seconds into mm:ss format.
    """
    m = int(seconds // 60)
    s = int(seconds % 60)
    return f"{m:02d}:{s:02d}"


def create_tooltip_text(
    artist, track, current_position_seconds, duration_seconds
) -> str:
    """
    Build the tooltip text showing artist, track, and current position vs duration.
    Use Pango markup to style the artist as italic and the track as bold.
    """
    tooltip = ""

    if artist or track:
        tooltip += f'<span foreground="{track_color}"><b>{track}</b></span>\n<span foreground="{artist_color}"><i>{artist}</i></span>\n'
        if duration_seconds > 0:
            progress = int((current_position_seconds / duration_seconds) * 20)
            bar = f'<span foreground="{progress_color}">{"━" * progress}</span><span foreground="{empty_color}">{"─" * (20 - progress)}</span>'
            tooltip += f'<span foreground="{time_color}">{format_time(current_position_seconds)}</span> {bar} <span foreground="{time_color}">{format_time(duration_seconds)}</span>'

    return tooltip


def write_output(track, artist, playing, player, tooltip_text):
    logger.info("Writing output")

    # Use the appropriate prefix based on playback status
    prefix = prefix_playing if playing else prefix_paused
    max_length = max_length_module

    # Calculate the total length and truncate track if necessary
    total_length = len(track) + len(artist)
    if total_length > max_length:
        available_length = max(0, max_length - len(artist))
        track = (
            f"{track[:available_length]}…" if len(track) > available_length else track
        )

    # Generate the "text" based on the presence of track and artist
    if track and not artist:
        output_text = f"{prefix}  <b>{track}</b>"
    elif track and artist:
        output_text = f"{prefix}  <i>{artist}</i>  <b>{track}</b>"
    else:
        output_text = "<b>Nothing playing</b>"

    output_data = {
        "text": output_text,
        "class": "custom-" + player.props.player_name,
        "alt": player.props.player_name,
        "tooltip": tooltip_text,
    }

    sys.stdout.write(json.dumps(output_data) + "\n")
    sys.stdout.flush()


def on_play(player, status, manager):
    logger.info("Received new playback status")
    on_metadata(player, player.props.metadata, manager)


def on_metadata(player, metadata, manager):
    """
    Called whenever the metadata changes (new track, etc.).
    We extract track, artist, total duration, store them in players_data,
    and immediately write the output once so it refreshes promptly.
    """
    logger.info("Received new metadata")

    # Grab track and artist
    full_track = player.get_title() or ""
    full_artist = player.get_artist() or ""
    track, artist = full_track, full_artist

    # Playback state
    playing = player.props.status == "Playing"

    # Duration and position
    length_microseconds = metadata["mpris:length"]
    duration_seconds = length_microseconds / 1e6
    current_position_seconds = player.get_position() / 1e6

    # Store relevant info so our timer callback can update the position every second
    players_data[player.props.player_name] = {
        "track": track,
        "artist": artist,
        "duration": duration_seconds,
    }

    # Build the tooltip
    tooltip_text = create_tooltip_text(
        artist, track, current_position_seconds, duration_seconds
    )
    write_output(track, artist, playing, player, tooltip_text)


def on_player_appeared(manager, player, selected_player=None):
    if player is not None and (
        selected_player is None or player.name == selected_player
    ):
        init_player(manager, player)
    else:
        logger.debug("New player appeared, but it's not the selected player, skipping")


def on_player_vanished(manager, player, loop):
    logger.info("Player has vanished")

    # Remove from our stored dictionary
    p_name = player.props.player_name
    if p_name in players_data:
        del players_data[p_name]

    # Output "standby" text
    output = {
        "text": standby_text,
        "class": "custom-nothing-playing",
        "alt": "player-closed",
        "tooltip": "",
    }

    sys.stdout.write(json.dumps(output) + "\n")
    sys.stdout.flush()


def init_player(manager, name):
    logger.debug("Initialize player: {player}".format(player=name.name))
    player = Playerctl.Player.new_from_name(name)
    player.connect("playback-status", on_play, manager)
    player.connect("metadata", on_metadata, manager)
    manager.manage_player(player)
    on_metadata(player, player.props.metadata, manager)


def update_positions(manager):
    """
    This is the callback run once every second.
    It loops over each known player, reads its current position,
    updates the tooltip, and rewrites the output to stdout.
    """
    # manager.props.players gives us the current active Player objects
    for player in manager.props.players:
        p_name = player.props.player_name
        # If we haven't stored metadata for this player yet, skip
        if p_name not in players_data:
            continue

        playing = player.props.status == "Playing"
        track = players_data[p_name]["track"]
        artist = players_data[p_name]["artist"]
        duration_seconds = players_data[p_name]["duration"]

        current_position_seconds = player.get_position() / 1e6
        tooltip_text = create_tooltip_text(
            artist, track, current_position_seconds, duration_seconds
        )

        write_output(track, artist, playing, player, tooltip_text)

    # Return True so the timer continues calling this function
    return True


def signal_handler(sig, frame):
    logger.info("Received signal to stop, exiting")
    sys.stdout.write("\n")
    sys.stdout.flush()
    # loop.quit()
    sys.exit(0)


class PlayerManager:
    def __init__(self, selected_player=None):
        self.manager = Playerctl.PlayerManager()
        self.loop = GLib.MainLoop()
        self.manager.connect(
            "name-appeared", lambda *args: self.on_player_appeared(*args))
        self.manager.connect(
            "player-vanished", lambda *args: self.on_player_vanished(*args))

        signal.signal(signal.SIGINT, signal_handler)
        signal.signal(signal.SIGTERM, signal_handler)
        signal.signal(signal.SIGPIPE, signal.SIG_DFL)
        self.selected_player = selected_player

        self.init_players()

    def init_players(self):
        for player in self.manager.props.player_names:
            if self.selected_player is not None and self.selected_player != player.name:
                logger.debug("%s is not the filtered player, skipping it", player.name)
                continue
            self.init_player(player)

    def run(self):
        logger.info("Starting main loop")
        self.loop.run()

    def init_player(self, player):
        logger.info("Initialize new player: %s", player.name)
        player = Playerctl.Player.new_from_name(player)
        player.connect("playback-status",
                       self.on_playback_status_changed, None)
        player.connect("metadata", self.on_metadata_changed, None)
        self.manager.manage_player(player)
        self.on_metadata_changed(player, player.props.metadata)

    def get_players(self) -> List[Player]:
        return self.manager.props.players

    def write_output(self, text, player, tooltip):
        logger.debug("Writing output: %s", text)

        output = {"text": text,
                  "class": "custom-" + player.props.player_name,
                  "alt": player.props.player_name,
                  "tooltip": tooltip}

        sys.stdout.write(json.dumps(output) + "\n")
        sys.stdout.flush()

    def clear_output(self):
        sys.stdout.write("\n")
        sys.stdout.flush()

    def on_playback_status_changed(self, player, status, _=None):
        logger.debug("Playback status changed for player %s: %s", player.props.player_name, status)
        self.on_metadata_changed(player, player.props.metadata)

    def get_first_playing_player(self):
        players = self.get_players()
        logger.debug("Getting first playing player from %d players", len(players))
        if len(players) > 0:
            # if any are playing, show the first one that is playing
            # reverse order, so that the most recently added ones are preferred
            for player in players[::-1]:
                if player.props.status == "Playing":
                    return player
            # if none are playing, show the first one
            return players[0]
        else:
            logger.debug("No players found")
            return None

    def show_most_important_player(self):
        logger.debug("Showing most important player")
        # show the currently playing player
        # or else show the first paused player
        # or else show nothing
        current_player = self.get_first_playing_player()
        if current_player is not None:
            self.on_metadata_changed(current_player, current_player.props.metadata)
        else:    
            self.clear_output()

    def on_metadata_changed(self, player, metadata, _=None):
        logger.debug("Metadata changed for player %s", player.props.player_name)
        player_name = player.props.player_name
        artist = player.get_artist()
        title = player.get_title()

        track_info = ""
        if player_name == "spotify" and "mpris:trackid" in metadata.keys() and ":ad:" in player.props.metadata["mpris:trackid"]:
            track_info = "Advertisement"
        elif artist is not None and title is not None:
            track_info = f"{artist} - {title}"
        else:
            track_info = title
        tooltip = track_info
        if track_info:
            if player.props.status == "Playing":
                track_info = " " + track_info
            else:
                track_info = " " + track_info
        # only print output if no other player is playing
        current_playing = self.get_first_playing_player()
        if current_playing is None or current_playing.props.player_name == player.props.player_name:
            self.write_output(track_info, player, tooltip)
        else:
            logger.debug("Other player %s is playing, skipping output", current_playing.props.player_name)

    def on_player_appeared(self, _, player):
        logger.info("Player has appeared: %s", player.name)
        if player is not None and (self.selected_player is None or player.name == self.selected_player):
            self.init_player(player)
        else:
            logger.debug(
                "New player appeared, but it's not the selected player, skipping")

    def on_player_vanished(self, _, player):
        logger.info("Player %s has vanished", player.props.player_name)
        self.show_most_important_player()

def parse_arguments():
    parser = argparse.ArgumentParser()

    # Increase verbosity with every occurrence of -v
    parser.add_argument("-v", "--verbose", action="count", default=0)

    # Define for which player we"re listening
    parser.add_argument("--player")

    parser.add_argument("--enable-logging", action="store_true")

    return parser.parse_args()


def main():
    arguments = parse_arguments()

    # Initialize logging
    if arguments.enable_logging:
        logfile = os.path.join(os.path.dirname(
            os.path.realpath(__file__)), "media-player.log")
        logging.basicConfig(filename=logfile, level=logging.DEBUG,
                            format="%(asctime)s %(name)s %(levelname)s:%(lineno)d %(message)s")

    # Logging is set by default to WARN and higher.
    # With every occurrence of -v it's lowered by one
    logger.setLevel(max((3 - arguments.verbose) * 10, 0))

    logger.info("Creating player manager")
    if arguments.player:
        logger.info("Filtering for player: %s", arguments.player)
    player = PlayerManager(arguments.player)
    player.run()


if __name__ == "__main__":
    main()
