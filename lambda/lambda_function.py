import json
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("aws-resume")


def lambda_handler(event, context):
    # Log request details to help with troubleshooting.
    print("BROWSER_REQUEST", json.dumps({
        "request_id": context.aws_request_id,
        "method": event.get("requestContext", {}).get("http", {}).get("method"),
        "path": event.get("rawPath"),
        "user_agent": event.get("headers", {}).get("user-agent")
    }))

    # Ignore favicon requests so they don't increase the counter.
    if event.get("rawPath") == "/favicon.ico":
        return {"statusCode": 204, "body": ""}

    result = table.update_item(
        Key={"id": "1"},
        UpdateExpression="ADD #v :one",
        ExpressionAttributeNames={"#v": "views"},
        ExpressionAttributeValues={":one": 1},
        ReturnValues="UPDATED_NEW"
    )

    views = int(result["Attributes"]["views"])

    return {
        "statusCode": 200,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps({"views": views})
    }