## setup

### secrets

```
# generate new private age key from ssh key
ssh-to-age -private-key -i ~/.ssh/<private_key> > ~/.config/sops/age/keys.txt

# get public key and add this to .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt

sops updatekeys secrets/secrets.yaml
```

