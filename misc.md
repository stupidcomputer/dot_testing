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
