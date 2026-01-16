package com.reto;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.AttributeValueUpdate;
import software.amazon.awssdk.services.dynamodb.model.AttributeAction;
import software.amazon.awssdk.services.dynamodb.model.UpdateItemRequest;
import java.util.HashMap;
import java.util.Map;

public class PutHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    // OPTIMIZACIÓN: Cliente estático fuera del handler para reutilizar conexión
    private static final DynamoDbClient ddb = DynamoDbClient.create();
    private static final Gson gson = new Gson();

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
        try {
            String id = request.getPathParameters().get("id");

            JsonObject body = gson.fromJson(request.getBody(), JsonObject.class);
            String nombre = body.get("nombre").getAsString();
            String email = body.get("email").getAsString();

            Map<String, AttributeValueUpdate> updates = new HashMap<>();
            updates.put("nombre", AttributeValueUpdate.builder()
                    .value(AttributeValue.builder().s(nombre).build())
                    .action(AttributeAction.PUT).build());
            updates.put("email", AttributeValueUpdate.builder()
                    .value(AttributeValue.builder().s(email).build())
                    .action(AttributeAction.PUT).build());

            ddb.updateItem(UpdateItemRequest.builder()
                    .tableName("usuarios-table")
                    .key(Map.of("id", AttributeValue.builder().s(id).build()))
                    .attributeUpdates(updates)
                    .build());

            return new APIGatewayProxyResponseEvent()
                    .withStatusCode(200)
                    .withBody("{\"message\": \"Usuario " + id + " actualizado correctamente\"}");

        } catch (Exception e) {
            return new APIGatewayProxyResponseEvent()
                    .withStatusCode(500)
                    .withBody("{\"error\": \"" + e.getMessage() + "\"}");
        }
    }
}