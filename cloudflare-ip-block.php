<?php

// Cloudflare credentials
$apiKey = '1eb16f9a2dd3f7f71b121e474d40dd7943f08';
$zoneId = 'd03323b6a10477efdc6bdb600a76725a';
$rulesetId = '01d7e2d4279b4286886d5f6701e6fb5e';

// API endpoints
$accessRulesApiUrl = "https://api.cloudflare.com/client/v4/zones/$zoneId/firewall/access_rules/rules";
$graphQlEndpoint = 'https://api.cloudflare.com/client/v4/graphql';

// GRAPHQL stuff //
function blockIpsWaf()
{
    // Query code here
}

function isIpBlocked($ip, $accessRulesApiUrl, $apiKey, $zoneId) {
    $curl = curl_init($accessRulesApiUrl);

    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, [
        "X-Auth-Email: lee.aplin@livebuzz.co.uk",
        "X-Auth-Key: $apiKey",
        "Content-Type: application/json"
    ]);

    $response = curl_exec($curl);
    $httpCode = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);

    if ($httpCode !== 200) {
        return false;
    }

    $data = json_decode($response, true);

    if (isset($data['result'])) {
        foreach ($data['result'] as $rule) {
            if ($rule['configuration']['target'] === 'ip' && $rule['configuration']['value'] === $ip && $rule['mode'] === 'block') {
                return true;
            }
        }
    }
    return false;
}

function blockIp($ip, $accessRulesApiUrl, $apiKey) {
    $data = [
        'mode' => 'block',
        'configuration' => [
            'target' => 'ip',
            'value' => $ip,
        ],
        'notes' => 'Blocked due to honeypot access',
    ];

    $curl = curl_init($accessRulesApiUrl);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($curl, CURLOPT_HTTPHEADER, [
        "X-Auth-Email: lee.aplin@livebuzz.co.uk",
        "X-Auth-Key: $apiKey",
        "Content-Type: application/json"
    ]);
    curl_setopt($curl, CURLOPT_POST, true);
    curl_setopt($curl, CURLOPT_POSTFIELDS, json_encode($data));

    $response = curl_exec($curl);
    curl_close($curl);

    $result = json_decode($response, true);

    if ($result && $result['success']) {
        echo "IP $ip has been blocked successfully.\n";
    } else {
        echo "Failed to block IP: " . json_encode($result) . "\n";
    }
}

// Assuming your code loops through each IP address:
// Foreach IP:
if (!isIpBlocked($ip, $accessRulesApiUrl, $apiToken, $zoneId)) {
    blockIp($ip, $accessRulesApiUrl, $apiToken);
} else {
    echo "IP $ip is already blocked.\n";
}
