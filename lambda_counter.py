import json
import boto3

def lambda_handler(event, context):
    # This function increments a counter that is stored in DynamoDB and returns the current count post increment.
    
    # Creates table resource
    table = boto3.resource('dynamodb', region_name='us-east-1').Table('resume-counter')
    # Uses table resource to fetch the current count and increment it by one.
    current_count = str(int(table.get_item(Key={'count': 'count'})['Item']['current_count']) + 1)
    # Update counter to the current_count
    table.put_item(Item={'count': 'count', 'current_count': current_count})
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET'
        },
        'body': json.dumps(current_count)
    }