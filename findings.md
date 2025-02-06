# Findings

This document lists findings of vulnerabilities in the Android version of the Flat Earth Sun & Moon Clock app and related API.

Findings are grouped by severity, and describe a cause, its effect, and recommendations for remediation. They are not a technical "how-to" for either exploiting or remediating the noted issues or vulnerabilities, and will not contain specific technical detail for either.

The severity levels are:
- [Critical](#critical)
- [High](#high)
- [Moderate](#moderate)
- [Low/Interesting](#lowinteresting)

## Critical

### [Resolved] Passwords Are Displayed in Plain-Text on the Leaderboard (`getListForLeaderboard`) and Friend Finder (`getProfilesRangeForUsers`) API Endpoints

This specific vulnerability has been patched. However, from the data structures returned and the app's interaction with the back-end API, the API appears to not be built in a way that would prevent this vulnerability from arising on the same or other endpoints.

Cause:

Not using a well-known and well-tested authentication library or product that employs security best practices.

Effect:

The password for any user can be easily retrieved, allowing a malicious actor to log in as any user.

In addition, coupled with users email addresses being similarly leaked, this can be combined with credential stuffing attacks to compromise a user's other accounts on other apps or services.

Recommendation:

1. Limit the data returned by API routes to only what is necessary for that route's intended purpose.
2. Utilize an OAuth2.0 identity provider. Microsoft, Google, Facebook, and others freely offer external identity provider endpoints that can be freely used for delegated authentication and identity. Products such as KeyCloak, Okta, Auth0, Amazon Cognito, and Microsoft Entra ID exist at varying levels of cost for customisable, internal user identities.

---

### Unsecured API Routes Can be Trivially Accessed by Obtaining A User's `user_id` or `device_id` From Other API Routes

Cause:

Insufficient and poor understanding of web development best practices.

Effect:

It is trivial to request data from the API as any user in the system. It is also possible in several places to make changes to a user's profile or settings.

In addition, any user's private messages may be viewed or even sent by someone who is not that user. This also includes sending friend requests as another user.

Recommendation:

Even using the [HTTP Basic Authentication Scheme](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#basic_authentication_scheme) on all API routes that should require protection would be a marked improvement over the current implementation.

If OAuth2.0 is used (as per previous recommendation), the JSON Web Token contains information about the user that should be used instead to identify the user data is to be retrieved for.

---

### Bearer Token Authentication Mechanism Allows Impersonation

Cause:

JWT Bearer tokens are created from just the `device_id`, and not as a result of user authentication.

Effect:

An attacker can trivially generate a Bearer token from any `device_id`. As the `device_id` is exposed in the response from a number of API endpoints, a Bearer token for each can be easily generated and then used for further requests. Combined with the `user_id`, any user and device can be easily impersonated. This appears to be an attempt to improve protection of API routes (as discussed above) but is barely better than merely requiring the `device_id` as a parameter given how easy it is to obtain a Bearer Token for a given `device_id`.

[misc/scripts/bearerTokenExample.sh] provides an example of how the current Bearer token implementation is completely ineffective in preventing unauthorized access.

Recommendation:

1. Even using the [HTTP Basic Authentication Scheme](https://developer.mozilla.org/en-US/docs/Web/HTTP/Authentication#basic_authentication_scheme) on all API routes that should require protection would be a marked improvement over the current implementation.
2. If OAuth2.0 is used (as per previous recommendation), the JSON Web Token contains information about the user that should be used instead to identify the user data is to be retrieved for.

---

## High

### Passwords Are Not Stored Using a Cryptographically Secure Hash Function

Cause: 

Poor understanding of authentication best practices, and not using an authentication library or framework.

Effect:

Passwords that are stored in plaintext can be easily leaked or exposed, either accidentally from other parts of the system (the API was leaking passwords previously), or from direct compromise of the database. **_Incorrectly and insufficiently secured passwords compromises the security and privacy of all users._** As people often reuse passwords, the exposure of their password for one application can often lead to the compromise of their other accounts (email, social media, banking).

Given that an authentication framework is likely not being used, standard best practices like requiring a minimum length or minimum password strength (for example, requiring a mixture of lowercase, uppercase, digits, and special characters) are likely not being employed either.

Recommendation:

1. Use a well-known and supported authentication library or framework. The Laravel PHP framework appears to be used for other areas of the API, and includes several libraries that correctly implement the authentication layer such as Laravel Fortify.

Evidence:

- Previous leaking of passwords indicate they are stored in plaintext.
- The "Forgot Password" mechanism sends the user their current password.
- There is no enforcement of minimum password length or strength.

---

## Moderate

### Distributing API Details via Firebase Reduces Security of the App, and Increases the Possibility of an Adversary-in-the-Middle Attack

Cause:

Poorly understood development practices by inexperienced developers.

Effect:

An attacker could create a HTTP proxy that records all data that passes through it, and have all installed apps pointed at this proxy by just changing the value stored in Firebase. The attempt at employing Bearer tokens (mentioned above) does little to alleviate this vulnerability.

Recommendation:

1. Having the API domain name in the app code also prevents an attacker from being able to hijack all users in the manner described here.

---

### User Locations are not Adequately Obfuscated, Permitting Trivial Reversing

Cause:

The app code intended to adjust the location by applying a random offset a number of times, however the implementation results in only one of a set of static offsets being applied, and always in a positive direction.

Effect:

Although the app allows users to select to share either a precise or approximate location, the approximate location is calculated in such a way that their actual precise location is easily able to be determined.

Recommendation:

1. At minimum, truncating the user's location to two or three decimal places should be adequate. Randomised offsets (chosen separately for latitude and longitude) can be added or subtracted to the _truncated value_ (i.e. generate two random numbers between -0.001 and +0.001, and apply one to the latitude and the other to the longitude).
2. Best practice is to employ algorithms such as NRand-K (Zurbarán M, Wightman P, Brovelli M, et al. NRand-K: Minimizing the impact of location obfuscation in spatial analysis. Transactions in GIS. 2018; 22: 1257–1274. https://doi.org/10.1111/tgis.12462), N-Dispersion, or N-Rand (Wightman, Pedro & Coronell, Winston & Jabba Molinares, Daladier & Jimeno, Miguel & Labrador, Miguel. (2011). Evaluation of Location Obfuscation techniques for privacy in location based information systems. https://doi.org/10.1109/LatinCOM.2011.6107399).

---

## Low/Interesting

## Low/Interesting

### Cryptocurrency Wallet Private Key and Wallet Address, and GoPulse API Key are Distributed in the .apk

Cause:

Effect:

An attacker has all the details they would need to continually transfer any and all cryptocurrency in this wallet to their own wallets.

Recommendation:

1. Complete removal of the code from the app code base.
2. Any transfers should be handled entirely server-side
3. Revoke the private key associated with the wallet and issue a new private+public key pair for the wallet. Alternatively, consider the wallet completely compromised and completely cease all use of it.
4. Revoke the GoPulse API key and create a new API key.
