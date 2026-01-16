package com.reto;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyRequestEvent;
import com.amazonaws.services.lambda.runtime.events.APIGatewayProxyResponseEvent;
import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DeleteItemRequest;
import java.util.Map;

public class DeleteHandler implements RequestHandler<APIGatewayProxyRequestEvent, APIGatewayProxyResponseEvent> {
    private static final DynamoDbClient ddb = DynamoDbClient.create();

    @Override
    public APIGatewayProxyResponseEvent handleRequest(APIGatewayProxyRequestEvent request, Context context) {
        String id = request.getPathParameters().get("id");

        ddb.deleteItem(DeleteItemRequest.builder()
                .tableName("usuarios-table")
                .key(Map.of("id", AttributeValue.builder().s(id).build()))
                .build());

        return new APIGatewayProxyResponseEvent()
                .withStatusCode(200)
                .withBody("{\"message\": \"Usuario " + id + " eliminado\"}");
    }
}