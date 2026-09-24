# Backend contract

API mode accepts an HTTPS origin (for example `https://api.example.com`), with no path, credentials, query, or fragment. Change the Retrofit annotations if your service uses a path prefix. Browser API deployments must permit the app's origin, JSON content type, and Authorization header through CORS.

## Sign in

`POST /auth/login`, JSON request:

```json
{"email":"demo@example.com","password":"Demo123!"}
```

Successful response (`200`):

```json
{
  "access_token":"opaque-bearer-token",
  "user":{"id":"demo-user","email":"demo@example.com","display_name":"Alex Morgan"}
}
```

The token must be nonempty. Invalid credentials return `401`. The client does not attach a stored token to this request.

Google/GitHub sign-in uses browser authorization through an identity backend and
`POST /auth/oauth/{provider}/exchange`, returning the same session payload. See
[the OAuth contract and platform setup](oauth.md) for PKCE, callbacks and provider
configuration. The included providers are simulated in demo mode.

## Restore or validate a session

`GET /auth/me`, with `Authorization: Bearer <access_token>`:

```json
{"id":"demo-user","email":"demo@example.com","display_name":"Alex Morgan"}
```

Expired or revoked sessions return `401`. Successful verification updates the current user. The auth interceptor handles `401` from any authenticated endpoint by invalidating the credential used by that request; an old response cannot clear a newer session. Public password/OAuth endpoints do not trigger invalidation. Timeouts and transport/server errors preserve credentials for retry. Generic failure messages are displayed; raw response bodies are not surfaced or logged.

Logout clears local credentials. There is no remote revocation endpoint or refresh-token contract in this starter. Add both explicitly in domain/data when supported by your service. Password validation only enforces nonempty/minimum-eight-character input for this demo; adapt it to your backend's login policy.

## Demo transport

`DemoAdapter` returns this same wire format without network access. `demo@example.com` + `Demo123!` signs in; `timeout@example.com` simulates timeout and `server@example.com` simulates `503`. Other credentials return `401`. The home-screen expiry button makes the next `/auth/me` return `401`.

Inject a different `HttpClientAdapter` qualified with `mainApi`, or replace `CredentialStore`, in tests. Standalone network-module tests provide `mainApi` bindings for `BaseOptions`, `SafeLoggingInterceptor`, and `HttpAuthentication`. Repository tests verify JSON decoding, mappings, storage failures, session expiry, and login/logout races; presentation tests verify user-facing state and duplicate-submit protection.
