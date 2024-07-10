export const handler = async (event) => {
  try {
    const lines = Buffer.from(event.body || "", "base64").toString("utf-8");
    console.log(lines);

    return send();
  } catch (error) {
    return send({ ...error }, 500);
  }
};

function send(body, statusCode = 200) {
  return {
    statusCode,
    headers: { "Content-Type": "application/json" },
    isBase64Encoded: false,
    multiValueHeaders: {},
    body: JSON.stringify(body ?? {}),
  };
}
