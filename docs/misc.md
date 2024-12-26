## cannot remove '/tmp/env-vars': Operation not permitted

If, when running nix-shell this happens:

```
coper:~/dot_testing/boxes/phone/init$ nvim shell.nix
coper:~/dot_testing/boxes/phone/init$ nix-shell
install: cannot remove '/tmp/env-vars': Operation not permitted
```

remove `/tmp/env-vars` (it's owned by root for some reason):

```
$ sudo rm /tmp/env-vars
```

Is there a fix for this?

## wireguard tunnel isn't working!

If one of your clients is showing 0 bytes recieved, then try changing the control port on both
the client and the server. See b6b86824def331d1a558aa7c5bd9f41bd3eb6aea for an example.
