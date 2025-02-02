# Findings of vulnerabilities in the "Flat Earth Clock" app

Welcome! In this repository we disclose findings of vulnerabilities in the Flat Earth Sun Moon & Clock app and its related HTTP API, published by Blue Water Bay.

In line with responsible disclosure practices, we first attempted to communicate with the app's developer/owner in October 2024. These efforts to communicate and disclose have been both ignored or responded to with hostility. We are now making these findings public after more than 90 days since the first communication attempts, in the interest of the safety and privacy of the app's users, and for the awareness of the broader flat earth research and debunking communities.

The vulnerabilities and other concerns are listed in [findings.md](findings.md).

## Current Users

If you are a user of the app on either Android or iOS, we **strongly** recommend you

1. Change your password! An earlier version of the app exposed passwords, and so you should consider your password compromised. If you use the same password for accounts in other apps or services, change your password there as well (and use different passwords for each app or service).
2. Remove any personally-identifiable information from the app, including your phone number, date of birth, and anything else you would not want to be publicly known. This data is also currently exposed with few safeguards, and can be used against you in social engineering attacks to gain access to things like your bank account.
3. Do not use the Friend Finder or any other location-based features. We would in fact recommend not using the app at all until the vulnerabilities are sufficiently addressed. In the case of the Friend Finder feature, the exact location of any user is provided with [unnecessary accuracy](https://xkcd.com/2170/), exposing your home address, place of work, etc. Even using the "approximate location" setting doesn't help, as the way it works can still be reversed to determine your exact location.

## Who Are We?

We are GlobeSec, a collective of software developers and infosec professionals investigating privacy and security risks in web and mobile apps developed by flat earthers. We are not associated with or working for these app developers. Our primary objective is to ensure that users' data remains safe from malicious actors, regardless of the users beliefs.