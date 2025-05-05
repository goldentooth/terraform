import base64
import boto3
import os

def authenticated(event):
  if event.get("headers", {}).get("authorization") is None:
    print("bad auth header");
    return False
  credentials = boto3.client("ssm").get_parameter(
    Name=os.getenv("CREDENTIALS_NAME"),
    WithDecryption=True,
  )["Parameter"]["Value"]
  auth = base64.b64decode(event["headers"]["authorization"].split(" ")[-1])
  print(f"auth header: {auth}")
  print(f"auth header decoded: {auth.decode("utf-8")}")
  return auth.decode("utf-8") == credentials

def handler(event, _):
  response = {
    "statusCode": 404,
    "headers": {
      "Content-Type": "text/plain"
    },
    "body": "",
  }

  if not authenticated(event):
    print("bad auth")
    return response

  if any(
    (
      (event.get("queryStringParameters", {}).get("hostname") is None),
      (event.get("queryStringParameters", {}).get("ip_address") is None),
    )
  ):
    print("bad query string parameters")
    return response

  try:
    boto3.client("route53").change_resource_record_sets(
      HostedZoneId=os.getenv("HOSTED_ZONE_ID"),
      ChangeBatch={
        "Comment": "Dynamic DNS Update",
        "Changes": [
            {
              "Action": "UPSERT",
              "ResourceRecordSet": {
                "Name": event["queryStringParameters"]["hostname"],
                "Type": "A",
                "TTL": int(event["queryStringParameters"].get("ttl", os.getenv("DEFAULT_TTL"))),
                "ResourceRecords": [
                  {
                    "Value": event["queryStringParameters"]["ip_address"],
                  },
                ],
              },
            }
        ],
      },
    )
    response["statusCode"] = 200
    response["body"] = "good"
  except Exception as e:
    print(e)
    return response
  except:
    print("unknown error")
    return response
  return response
