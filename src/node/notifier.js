const AWS = require('aws-sdk');
const sns = new AWS.SNS();

exports.handler = async (event) => {
    try {
        for (const record of event.Records) {
            const userData = JSON.parse(record.body);
            
            const params = {
                TopicArn: process.env.SNS_TOPIC_ARN,
                Message: `Hola! Se ha creado un nuevo usuario.\nNombre: ${userData.nombre}\nEmail: ${userData.email}`,
                Subject: 'Nuevo Usuario Registrado'
            };

            await sns.publish(params).promise();
            console.log("Notificación enviada para:", userData.email);
        }
    } catch (error) {
        console.error("Error procesando notificación:", error);
    }
};