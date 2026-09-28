# Security Test Matrix

## Economy abuse
- send negative purchase amount (not part of any public API)
- request unknown tool/vehicle/employee ID
- purchase owned item twice
- purchase without sufficient funds
- race two purchase requests
- spoof Cash/XP through client attributes
- replay completed job instance
- complete stage out of order
- complete stage faster than configured minimum
- perform action far from job anchor

## Purchase abuse
- send unknown pass/product key
- spoof Prompt* completion client-side
- retry identical Developer Product receipt
- reconnect during receipt save
- unconfigured ProductId in ProcessReceipt
- player absent during ProcessReceipt

## Co-op abuse
- join full contract
- action without membership
- replay final stage
- leave owner mid-contract
- zero-contribution reward attempt
- reconnect during contract

## Expected result
Every case must reject or safely defer without granting duplicate persistent value.

Automated pure-Luau tests cover configuration/invariant logic. Runtime remote abuse cases require Roblox Studio multi-client verification before public launch.
