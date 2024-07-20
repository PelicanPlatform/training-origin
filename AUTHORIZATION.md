
# PEARC24 Pelican Tutorial - Authorization Module

This page contains the materials that will be used during the
[PEARC24 tutorial](https://pearc.acm.org/pearc24/workshops-and-tutorials/)
on how to use a Pelican data federation.

<!--
The corresponding slides can be found [here](https://example.com/todo)
-->

The following instructions assume you have followed the first module of the tutorial
on setting up your own origin; for this module, we will use the same environment
with the Pelican client installed.  Verify that Pelican is available in your currently-running
shell environment by verifying you have a recent version of the client:

```
$ pelican --version
Version: 7.9.3
Build Date: 2024-07-02T14:48:46Z
Build Commit: 5a3ee6d8633036a7dde45b2fcd34f1154995041a
Built By: goreleaser
```

If the above command did not work, please follow the (setup)[#setup] section; otherwise, you
may proceed to [Acquiring a Token](#acquiring-a-token)

This module was tested with Pelican version 7.9.3.

**Jump to:**

* [Setup](#setup)
* [Acquiring a Token](#acquiring-a-token)
* [Inspecting Your Token](#inspecting-a-token)
* [Testing object upload and download](#testing-object-upload-and-download)

## Setup

> These setup instructions can be skipped if you already have the pelican client installed

The `pelican` binary must first be downloaded and installed into your shell environment.
To do this, [follow the Pelican installation page](https://docs.pelicanplatform.org/install).  A
simplified Linux-only version of the instructions are found below:

```
mkdir -p ~/.local/bin
pushd ~/.local/bin
curl -Ls https://github.com/PelicanPlatform/pelican/releases/download/v7.9.3/pelican_Linux_x86_64.tar.gz | tar zx --strip-components=1 pelican-7.9.3/pelican
popd
export PATH=~/.local/bin:$PATH
```

These steps:

- Create a subdirectory within your home directory to hold the Pelican executable (if it doesn't already exist)
- Downloads and unpacks the `pelican` binary into your home directory.
- Configures the `$PATH` environment variable so the binary can be found by default.

If `~/.local/bin` is not already in your `PATH` variable, the last line will need to be repeated for each terminal you open.

## Acquiring a Token

Each object in the data federation can be broken into two parts - the _namespace prefix_ and the _object name_.  For this
module, we have created a sample origin in the test federation at <https://tutorial-origin.osdf-dev.chtc.io/> associated
with the namespace `/pearc24-tutorial`.  Inside the object store behind the origin, we have an object named `/protected/hello_world.txt`.

Thus, the full federation name is:

```
/pearc24-tutorial/protected/hello_world.txt
 ^^ Prefix ^^        ^^ Object name ^^
```

We are using the token issuer built-in to the origin; so, for this object we will need a token with *read* authorization for the
prefix */protected* from the `https://tutorial-origin.osdf-dev.chtc.io` issuer.

- How do we get this token?
- How is a user supposed to know all this?!

Luckily, the client handles all this for us!  The director informs the client how to generate a token (if it is needed) and
the client can acquire tokens using OAuth2-based workflows.

Let's try it out.  Execute the following:

```
pelican object copy pelican://osdf-itb.osg-htc.org/pearc24-tutorial/protected/hello_world.txt /tmp/hello_world.txt
```

Note the familiar `pelican://` URL syntax and the object name.  The client will have output similar to this:

```
$ pelican object copy pelican://osdf-itb.osg-htc.org/pearc24-tutorial/protected/hello_world.txt /tmp/hello_world_protected.txt
The client is able to save the authorization in a local file.
This prevents the need to reinitialize the authorization for each transfer.
You will be asked for this password whenever a new session is started.
Please provide a new password to encrypt the local OSDF client configuration file: 

```

The client will store your credentials encrypted on disk to avoid a web browser interaction for each invocation;
this prompt is asking you to set an encryption password.  Type your preferred password and hit enter.

Now the client will request a token on your behalf; the issuer will require you to go to a URL to authorize the
request:

```
$ pelican object copy pelican://osdf-itb.osg-htc.org/pearc24-tutorial/protected/hello_world.txt /tmp/hello_world_protected.txt
The client is able to save the authorization in a local file.
This prevents the need to reinitialize the authorization for each transfer.
You will be asked for this password whenever a new session is started.
Please provide a new password to encrypt the local OSDF client configuration file: 

To approve credentials for this operation, please navigate to the following URL and approve the request:

https://tutorial-origin.osdf-dev.chtc.io/api/v1.0/issuer/device?user_code=8E2_1F6_F28
```

You will be prompted to sign in via CILogon when you go to this page.  Please sign in with the same account you used for registering at the tutorial.

> *Bug Alert!*  Pelican 7.9.3 does not correctly redirect the browser back to the prompt.  If you end up at the origin home page (with a permission denied), copy/paste the URL a second time.

Depending on the speed of your internet connection, you may or may not see a progress bar as the file downloads.  Verify you received the test file:

```
$ cat /tmp/hello_world_protected.txt
hello world
```

## Inspecting Your Token

What just happened?

- Given our object name, the director informed the client what issuer to use and the client calculated the scopes it needed in the token.
- The client requested an appropriate token from the issuer.
- The issuer had you authenticate via the browser to determine your username and group membership.
- The issuer ran logic determining your privileges then intersected those with the requested scopes.
- If all went well, the issuer returned an _access token_ and _refresh token_.  The access token is used for authorizing the data access.  The refresh token allows the client to request tokens in the future without the browser interaction and is saved in an encrypted file.

Let's look at the tokens we received.  Use the `pelican credentials print` command to dump your credentials to the terminal:

```
$ pelican credentials print
The OSDF client configuration is encrypted.  Enter your password for the local OSDF client configuration file: 

OSDF:
    oauth_client:
        - prefix: /pearc24-tutorial
          client_id: oa4mp:/client_id/48b20795ab304340d7de294be59e19fb
          client_secret: r96W8iJW-REDACTED-oh0ME3A5
          tokens:
            - expiration: 1721344087
              access_token: eyJraWQiOiJEYnNYOTFfRUVYYTB0VnFsU1NwWFhDaDNMMExJc3V4YS1xN3Q5cEJMdkxJIiwidHlwIjoiSldUIiwiYWxnIjoiRVMyNTYifQ.eyJ3bGNnLnZlciI6IjEuMCIsImF1ZCI6Imh0dHBzOi8vd2xjZy5jZXJuLmNoL2p3dC92MS9hbnkiLCJzdWIiOiJib2NrZWxtYW5Ad2lzYy5lZHUiLCJuYmYiOjE3MjEzNDMxODIsInNjb3BlIjoic3RvcmFnZS5tb2RpZnk6L3Byb3RlY3RlZCBzdG9yYWdlLnJlYWQ6L3Byb3RlY3RlZCBzdG9yYWdlLmNyZWF0ZTovaG9tZS9ib2NrZWxtYW5Ad2lzYy5lZHUgc3RvcmFnZS5jcmVhdGU6L3Byb3RlY3RlZCBzdG9yYWdlLnJlYWQ6L2hvbWUvYm9ja2VsbWFuQHdpc2MuZWR1IHN0b3JhZ2UubW9kaWZ5Oi9ob21lL2JvY2tlbG1hbkB3aXNjLmVkdSBzdG9yYWdlLnJlYWQ6L3JlYWQtb25seSIsImlzcyI6Imh0dHBzOi8vdHV0b3JpYWwtb3JpZ2luLm9zZGYtZGV2LmNodGMuaW8iLCJleHAiOjE3MjEzNDQwODcsImlhdCI6MTcyMTM0MzE4NywianRpIjoiaHR0cHM6Ly90dXRvcmlhbC1vcmlnaW4ub3NkZi1kZXYuY2h0Yy5pby9hcGkvdjEuMC9pc3N1ZXIvNjM0ZGMwMjUzNjNkZjE0YmRjZWQ2YzlmMTQwMzgyMDY_dHlwZT1hY2Nlc3NUb2tlbiZ0cz0xNzIxMzQzMTg2NzI0JnZlcnNpb249djIuMCZsaWZldGltZT05MDAwMDAifQ.L6wKMO3xKoT4_sSYoCk_F_8IZ1RYf1hD1kHWHeG6xRXPlIv1VaDXVfkU2sMNXL1T-EQuwXLyAjTL1_5GMNXn0Q
              refresh_token: NB2HI4DTHIXS65DVORXXE2LBNQWW64TJM5UW4LTPONSGMLLEMV3C4Y3IORRS42LPF5QXA2JPOYYS4MB-REDACTED
```

What information is here?

- Information is kept per-prefix, allowing credentials to be created for different parts of the namespace.
- The OAuth2 client ID and secret identify the local installation.  These were automatically generated.
- Refresh token for auto-updating the tokens.
- Access token, a JWT that will be used for data access within the namespace prefix.

Remember that the JWT is base64-encoded JSON objects.  Let's decode the token and see what's inside.  Copy/paste the `access_token` from your terminal into the service at <https://jwt.io> which helps you visualize the contents of JWTs.

> Note: The token is a credential!  We are doing this as a learning exercise; do not otherwise copy your token into a website

Here's the decoded payload contents from the example with annotations:

```
{
  "wlcg.ver": "1.0",
  "aud": "https://wlcg.cern.ch/jwt/v1/any",
  "sub": "example@pelicanplatform.org",       # Taken from the ePPN provided to CILogon
  "nbf": 1721343182,                          # Unix timestamp, not valid before 18 July 2024 at 17:53:02
  "scope": "storage.modify:/protected storage.read:/protected storage.create:/home/example@pelicanplatform.org storage.create:/protected storage.read:/home/example@pelicanplatform.org storage.modify:/home/example@pelicanplatform.org storage.read:/read-only",
  "iss": "https://tutorial-origin.osdf-dev.chtc.io",  # Identifier of the issuer at the origin
  "exp": 1721344087,                          # Expires at 18:08:07; a 15 minute lifetime
  "iat": 1721343187,
  "jti": "https://tutorial-origin.osdf-dev.chtc.io/api/v1.0/issuer/634dc025363df14bdced6c9f14038206?type=accessToken&ts=1721343186724&version=v2.0&lifetime=900000"
}
```

Note the permissions provided in the scopes:

- Read and modify the `/protected` namespace.  This permits the access to the object `/pearc24-tutorial/protected/hello_world.txt`.
- Read and modify `/home/example@pelicanplatform.org`.
- Read-only for `/read-only`.

What permissions do you see in your token?

The authorization rules are based on the configuration of the origin.  Here's the configuration in the tutorial origin:

```
Origin:
    EnableIssuer: true
Issuer:
   AuthenticationSource: OIDC
   OIDCAuthenticationUserClaim: eppn
   GroupSource: oidc
   # Requires membership of `pelican-training-login` to get any scopes at all
   GroupRequirements: ["pelican-training-login"]
   AuthorizationTemplates:
   - actions: ["read", "modify", "create"]
     prefix: /home/$USER
   - actions: ["read"]
     prefix: /read-only
   - actions: ["read", "modify", "create"]
     prefix: /protected
```

## Testing object upload and download

Now that we have a token and understand what it can do, try a few example data movements.

Download a sample 100MB file from the read-only directory:

```
pelican object get pelican://osdf-itb.osg-htc.org/pearc24-tutorial/read-only/100MB.dat /tmp/100MB.dat
```

Upload this file to your home directory (replace `example@pelicanplatform.org` with your username)

```
pelican object put /tmp/100MB.dat pelican://osdf-itb.osg-htc.org/pearc24-tutorial/example@pelicanplatform.org/100MB.dat
```

> Try uploading to `/pearc24-tutorial/read-only/100MB.dat`.  What error do you see?

You should be able to list the object you've uploaded:

```
pelican object ls pelican://osdf-itb.osg-htc.org/pearc24-tutorial/home/example@pelicanplatform.org
```

and download it back again

```
pelican object get pelican://osdf-itb.osg-htc.org/pearc24-tutorial/home/example@pelicanplatform.org /tmp/100MB.download
```

This should be a success!  Try a few other sub-commands of `pelican object` to explore the origin:

- *get*: Get an object from a Pelican federation
- *ls*: List objects in a namespace from a federation
- *put*: Send a file to a Pelican federation
- *stat*: Stat objects in a namespace from a federation

