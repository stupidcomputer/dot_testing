{ lib, config, pkgs, ...}:

{
  services = {
    guacamole-server = {
      enable = true;
      host = "127.0.0.1";
      port = 4823;
      userMappingXml = (
        builtins.toFile "mapping.xml" (
          builtins.replaceStrings
            [ "hashedUserPassword" ]
            [(
              lib.removeSuffix
                "\n"
                # echo -n PASSWORD | openssl dgst -sha256 | awk -F' ' '{print $2}'
                ( builtins.readFile /home/usr/wg-keys/guacamole-server-credentials )
            )]
            ( builtins.readFile ./mapping.xml )
        )
      );
    };

    guacamole-client = {
      enable = true;
      enableWebserver = true;
      settings = {
        guacd-port = 4823;
        guacd-hostname = "127.0.0.1";
      };
    };

    tomcat.serverXml = builtins.readFile ./server.xml;

    openssh = {
      enable = true;
      listenAddresses = [
        {
          addr = "127.0.0.1";
          port = 22;
        }
      ];
    };
  };
}
