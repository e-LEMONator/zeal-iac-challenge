import json
import boto3
import os
import logging
from botocore.exceptions import ClientError

# Initialize DynamoDB resource and table
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

# Setup Logging for Lambda to CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Main entry point for the Lambda function.
    Determines the HTTP method and calls the appropriate function.
    """
    logger.info(f"Received event: {event}")

    body = event.get('body')
    if isinstance(body, str):
        try:
            event['body'] = json.loads(body)
        except json.JSONDecodeError:
            logger.error("Invalid JSON in request body")
            return {
                'statusCode': 400,
                'body': json.dumps('Invalid JSON')
            }

    http_method = event.get('httpMethod')
    if http_method == 'POST':
        return create_contact(event)
    elif http_method == 'GET':
        return get_contact(event)
    elif http_method == 'PUT':
        return update_contact(event)
    elif http_method == 'DELETE':
        return delete_contact(event)
    else:
        logger.error(f"Method Not Allowed: {http_method}")
        return {
            'statusCode': 405,
            'body': json.dumps('Method Not Allowed')
        }

def create_contact(event):
    """
    Handles the creation of a new contact.
    """
    data = event.get('body', {})
    contact_id = event['queryStringParameters'].get('contact_id')
    if not contact_id:
        logger.error("Missing contact_id in create_contact")
        return {
            'statusCode': 400,
            'body': json.dumps('Missing contact_id')
        }
    data['contact_id'] = contact_id
    try:
        response = table.put_item(Item=data)
        logger.info(f"Contact created: {data}")
        return {
            'statusCode': 201,
            'body': json.dumps('Contact created')
        }
    except ClientError as e:
        logger.error(f"Error creating contact: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error creating contact: {e.response['Error']['Message']}")
        }

def get_contact(event):
    """
    Handles retrieving a contact by contact_id.
    """
    contact_id = event['queryStringParameters'].get('contact_id')
    if not contact_id:
        logger.error("Missing contact_id in get_contact")
        return {
            'statusCode': 400,
            'body': json.dumps('Missing contact_id')
        }
    try:
        response = table.get_item(Key={'contact_id': contact_id})
        if 'Item' in response:
            logger.info(f"Contact retrieved: {response['Item']}")
            return {
                'statusCode': 200,
                'body': json.dumps(response['Item'])
            }
        logger.warning(f"Contact not found: {contact_id}")
        return {
            'statusCode': 404,
            'body': json.dumps('Contact not found')
        }
    except ClientError as e:
        logger.error(f"Error retrieving contact: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error retrieving contact: {e.response['Error']['Message']}")
        }

def update_contact(event):
    """
    Handles updating an existing contact by contact_id.
    """
    data = event.get('body', {})
    contact_id = event['queryStringParameters'].get('contact_id')
    if not contact_id:
        logger.error("Missing contact_id in update_contact")
        return {
            'statusCode': 400,
            'body': json.dumps('Missing contact_id')
        }
    try:
        response = table.update_item(
            Key={'contact_id': contact_id},
            UpdateExpression="set #name = :name, address = :address",
            ExpressionAttributeNames={
                '#name': 'name'
            },
            ExpressionAttributeValues={
                ':name': data.get('name'),
                ':address': data.get('address')
            },
            ReturnValues="UPDATED_NEW"
        )
        logger.info(f"Contact updated: {contact_id}")
        return {
            'statusCode': 200,
            'body': json.dumps('Contact updated')
        }
    except ClientError as e:
        logger.error(f"Error updating contact: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error updating contact: {e.response['Error']['Message']}")
        }

def delete_contact(event):
    """
    Handles deleting a contact by contact_id.
    """
    contact_id = event['queryStringParameters'].get('contact_id')
    if not contact_id:
        logger.error("Missing contact_id in delete_contact")
        return {
            'statusCode': 400,
            'body': json.dumps('Missing contact_id')
        }
    try:
        response = table.delete_item(Key={'contact_id': contact_id})
        logger.info(f"Contact deleted: {contact_id}")
        return {
            'statusCode': 200,
            'body': json.dumps('Contact deleted')
        }
    except ClientError as e:
        logger.error(f"Error deleting contact: {e.response['Error']['Message']}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error deleting contact: {e.response['Error']['Message']}")
        }