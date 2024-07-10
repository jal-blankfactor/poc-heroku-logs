import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";
const { DRAIN_TOKEN_PARAM_NAME } = process.env;

export const handler = async (event) => {
  let isAuthorized = false;
  try {
    const drainToken = await getParameter(DRAIN_TOKEN_PARAM_NAME);
    isAuthorized = event.headers["logplex-drain-token"] === drainToken;
  } catch (error) {
    console.error(error);
  } finally {
    return {
      isAuthorized,
      context: {},
    };
  }
};

async function getParameter(name) {
  const input = {
    Name: name,
    WithDecryption: true,
  };
  try {
    const client = new SSMClient();
    const command = new GetParameterCommand(input);
    const response = await client.send(command);
    return response?.Parameter?.Value;
  } catch (error) {
    console.error(error);
    return;
  }
}
