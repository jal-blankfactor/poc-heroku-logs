import type { APIGatewaySimpleAuthorizerResult, Handler } from "aws-lambda";
import type { APIGatewayProxyEventV2 } from "aws-lambda";
import {
  GetSecretValueCommand,
  SecretsManagerClient,
} from "@aws-sdk/client-secrets-manager";
const { DRAIN_TOKEN_PARAM_NAME } = process.env;

export const handler: Handler = async (
  event: APIGatewayProxyEventV2
): Promise<APIGatewaySimpleAuthorizerResult> => {
  let isAuthorized = false;
  try {
    const drainToken = await GetSecret(DRAIN_TOKEN_PARAM_NAME!);
    isAuthorized = event.headers["logplex-drain-token"] === drainToken;
  } catch (error) {
    console.error(error);
  } finally {
    return {
      isAuthorized,
    };
  }
};

async function GetSecret(name: string) {
  const input = {
    SecretId: name,
  };
  try {
    const client = new SecretsManagerClient();
    const command = new GetSecretValueCommand(input);
    const response = await client.send(command);
    return response.SecretString;
  } catch (error) {
    console.error(error);
    return;
  }
}
