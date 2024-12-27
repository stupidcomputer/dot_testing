{
  age.secrets.gitea-postgres-password = {
    file = ../../secrets/gitea-postgres-password.age;
    mode = "0700";
    owner = "gitea";
    group = "gitea";
  };
}
