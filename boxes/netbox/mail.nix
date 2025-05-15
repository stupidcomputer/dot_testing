{ config, inputs, ... }:
{
  imports = [
    inputs.simple-nixos-mailserver.nixosModule
  ];

  age.secrets = {
    mailaccount = {
      file = ../../secrets/mailaccount.age;
    };
  };

  mailserver = {
    enable = true;
    fqdn = "mail.beepboop.systems";
    domains = [ "beepboop.systems" ];
    loginAccounts = {
      "ryan@beepboop.systems" = {
        # nix-shell -p mkpasswd --run 'mkpasswd -sm bcrypt' > /hashed/password/file/location
        hashedPasswordFile = config.age.secrets.mailaccount.path;

        aliases = [
            "info@beepboop.systems"
            "postmaster@beepboop.systems"
            "azpau5xfumqtud6hvf5g@beepboop.systems"
            "3jvhgykoff73uauemlbk@beepboop.systems"
            "8awqaeq8hycc56a3o9ac@beepboop.systems"
            "uhttg9qs5qpvmp5eoqh2@beepboop.systems"
            "ar1oztqzkx3k9m5roqis@beepboop.systems"
            "poyqbvwsihoa77dv0q66@beepboop.systems"
            "w1b2u69825uvx38ycpr6@beepboop.systems"
            "u9r0shommws30fx4jmk1@beepboop.systems"
            "bz48rp4d7whfh6yhg2yw@beepboop.systems"
            "psc7lwba31eepq9dqs79@beepboop.systems"
            "g2ptc8vi37qo5beaav4t@beepboop.systems"
            "s5c9d74lkbmwcewmn04k@beepboop.systems"
            "nzd3ni0km3nf0oux7jxk@beepboop.systems"
            "677bpmiz9ruimvgl9mfz@beepboop.systems"
            "elz4fe6085gyjsgphzka@beepboop.systems"
            "wyjyykwqwau6h7gx9aws@beepboop.systems"
            "gmbl1u0e3dnnei5e3n7f@beepboop.systems"
            "pbf2tgudf3zpuf8lb2ly@beepboop.systems"
            "jba0s9lmygbwvbiq23va@beepboop.systems"
            "xmf5c3y30xzgqzkop1lu@beepboop.systems"
            "50k3jkbud8ibvp1weqil@beepboop.systems"
            "4k38c2nlwu12jhnphzjc@beepboop.systems"
            "b90vsr1u6fwdpkuakbnl@beepboop.systems"
            "abn36c2zgxwwny4di0ft@beepboop.systems"
            "72ov2136gjezxqtyhdfq@beepboop.systems"
            "0tpio8spxf5xjpwki8yf@beepboop.systems"
            "okdzh5b8qlfcnnyonjou@beepboop.systems"
            "jmftgb4xdc47fj00y3wt@beepboop.systems"
            "ve3y5uc519rtml015vsb@beepboop.systems"
            "c4a73bcf7n34aetic1v4@beepboop.systems"
            "8n496rdb1hy55v1obu6m@beepboop.systems"
            "2prbq7atayzx3ib2icrv@beepboop.systems"
            "2qp4mzixcd5vu47wsf6f@beepboop.systems"
            "ulzpecrc95b4pwwljez7@beepboop.systems"
            "ptl8jwihkjri2mzxwknm@beepboop.systems"
            "5y6wbp0y1hnwimaupzu3@beepboop.systems"
            "cib4pn234z0dfj0s7hy6@beepboop.systems"
            "s2h18yf8pud12esfhqgg@beepboop.systems"
            "lg6xdsfmw5prpql6qzok@beepboop.systems"
            "22h9u6jmygym66kovqf3@beepboop.systems"
            "wranx7mhu4zl8rj6mabp@beepboop.systems"
            "hxm4f50sp1ntixlfrkyb@beepboop.systems"
            "iquga327gd6fm2peehpm@beepboop.systems"
            "z0ks51mxw5ofl81h0g05@beepboop.systems"
            "ycp6pcp8yrdn5pudoyit@beepboop.systems"
            "peowiksx1x4aoqye9ggu@beepboop.systems"
            "wue0w1b73ziy6ba428uh@beepboop.systems"
            "j8ecssr4gctcodkbxg6d@beepboop.systems"
            "ossteavihgx8ml0b59b5@beepboop.systems"
            "9sdhpkd4lhhbo86lci61@beepboop.systems"
        ];
      };
    };
    certificateScheme = "acme-nginx";
  };
}
