const AWS = require('aws-sdk');
const dynamo = new AWS.DynamoDB.DocumentClient();
const sqs = new AWS.SQS();

exports.handler = async (event) => {
    try {
        const body = JSON.parse(event.body);

        await dynamo.put({
            TableName: 'usuarios-table',
            Item: body
        }).promise();

        await sqs.sendMessage({
            QueueUrl: process.env.SQS_URL || 'PONER_URL_AQUI_O_USAR_VARIABLE',
            MessageBody: JSON.stringify(body)
        }).promise();

        return {
            statusCode: 201,
            body: JSON.stringify({ message: "Usuario creado y evento encolado", data: body })
        };
    } catch (error) {
        return { statusCode: 500, body: JSON.stringify({ error: error.message }) };
    }
};