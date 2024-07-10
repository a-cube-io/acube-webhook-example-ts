// src/index.ts
import express, {Request, Response} from 'express';

import axios from 'axios';
import {
  parseRequestSignature,
  verifyParsedSignature
} from "@misskey-dev/node-http-message-signatures";

async function getKeyId(): Promise<string> {
  const response = await axios.get('https://common-sandbox.api.acubeapi.com/signature-public-key');
  return response.data.public_key;
}

async function verifyHttpSignature(request: Request): Promise<boolean> {
  const publicKey = await getKeyId(); // Ideally, cache or retrieve more efficiently
  try {
    let parsedSignature = parseRequestSignature(request);

    return await verifyParsedSignature(parsedSignature, publicKey, (...args) => console.log(args));
  } catch (error) {
    console.error(error);
    return false;
  }
}

const app = express();

app.post('/my_webhook', async (req: Request, res: Response) => {
  if (!await verifyHttpSignature(req)) {
    return res.status(401).send({message: 'Invalid http signature'});
  }
  console.log('Valid signature received');
  res.send({message: 'Done'});
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on ${PORT}`);
});

