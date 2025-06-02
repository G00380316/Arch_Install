To setup Onedrive start off by typing into the terminal of your choice this command:

```
onedrive --reuth
```

Copy the url the command outputs and go to your browser paste and then login into your account then you will be redirected to a page that is blank copy the url in the address bar paste it into the terminal

Next create a folder in your home dir or you can just use root
For example we will use Onedrive dir in our home directory

```
onedrive --syncdir --monitor Onedrive
```

Then it will start to bidirectionally sync your local dir and Onedrive 

to get this to work automatically in your config file for your desktop environment add this command or something similiar. I am on hyprland so it will be this

```
exec-once = onedrive --monitor --force --resync-auth  --disable-notifications
```

