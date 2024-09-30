import json
import boto3
import os
from botocore.exceptions import ClientError

# Initialize DynamoDB resource and table
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])

def lambda_handler(event, context):
    """
    Main entry point for the Lambda function.
    Determines the HTTP method and calls the appropriate function.
    """
    body = event.get('body')
    if isinstance(body, str):
        try:
            event['body'] = json.loads(body)
        except json.JSONDecodeError:
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
        return {
            'statusCode': 405,
            'body': json.dumps('Method Not Allowed')
        }

def create_contact(event):
    """
    Handles the creation of a new contact.
    """
    data = event.get('body', {})
    try:
        response = table.put_item(Item={
            'contact_id': data.get('contact_id'),
            'name': data.get('name'),
            'address': data.get('address'),
            # other fields can be added here
        })
        return {
            'statusCode': 201,
            'body': json.dumps('Contact created')
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error creating contact: {e.response['Error']['Message']}")
        }

def get_contact(event):
    """
    Handles retrieving a contact by contact_id.
    """
    data = event.get('body', {})
    contact_id = data.get('contact_id')
    try:
        response = table.get_item(Key={'contact_id': contact_id})
        if 'Item' in response:
            return {
                'statusCode': 200,
                'body': json.dumps(response['Item'])
            }
        return {
            'statusCode': 404,
            'body': json.dumps('Contact not found')
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error retrieving contact: {e.response['Error']['Message']}")
        }

def update_contact(event):
    """
    Handles updating an existing contact by contact_id.
    """
    data = event.get('body', {})
    contact_id = data.get('contact_id')
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
        return {
            'statusCode': 200,
            'body': json.dumps('Contact updated')
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error updating contact: {e.response['Error']['Message']}")
        }

def delete_contact(event):
    """
    Handles deleting a contact by contact_id.
    """
    data = event.get('body', {})
    contact_id = data.get('contact_id')
    try:
        response = table.delete_item(Key={'contact_id': contact_id})
        return {
            'statusCode': 200,
            'body': json.dumps('Contact deleted')
        }
    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error deleting contact: {e.response['Error']['Message']}")
        }