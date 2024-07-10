import type { Handler } from "aws-lambda";
import type {
  APIGatewayProxyEventV2,
  APIGatewayProxyResultV2,
} from "aws-lambda";

export const handler: Handler = async (
  event: APIGatewayProxyEventV2
): Promise<APIGatewayProxyResultV2> => {
  try {
    const lines = Buffer.from(event.body || "", "base64").toString("utf-8");
    console.log(lines);

    return send();
  } catch (error: any) {
    return send({ message: error.message }, 500);
  }
};

function send(body: any = {}, statusCode = 200): APIGatewayProxyResultV2 {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    isBase64Encoded: false,
    body: JSON.stringify(body),
  };
}
