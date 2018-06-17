A Simple Mastodon Client
------------------------

tags: Mastodon, curl;

First, the client must be registered:

```sh
curl -d '{"client_name":"Your Client Name", "redirect_uris":"urn:ietf:wg:oauth:2.0:oob", "scopes":"read write follow"}'\
  -H "Content-Type: application/json"\
  -X POST https://mastodon.social/api/v1/apps
```

The return is a JSON with the **clienti_id** and **client_secret**. With the informations, we can get the access token:

```sh
curl -X POST\
  -d 'client_id=[your client_id]&client_secret=[Your client_secret]&grant_type=password&username=[your email]&password=[your password]&scope=read%20write%20follow'\
  -Ss https://mastodon.social/oauth/token
```

Note that the **scopes** must be specified both at the client registration and access token application. And the password should be encoded with URL Encoding.

Now we can send a toot with curl:

```sh
curl -X POST -d '{"status":"test"}'\
  -H "Content-Type: application/json"\
  --header "Authorization: Bearer [The access token]"\
  -sS https://mastodon.social/api/v1/statuses
```

Refer:

* https://github.com/tootsuite/documentation/blob/master/Using-the-API/API.md
* https://github.com/tootsuite/documentation/blob/master/Using-the-API/Testing-with-cURL.md
