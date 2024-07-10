import express, {Request, Response} from 'express';
import axios from 'axios';
import jwt from 'jsonwebtoken';
import {IncomingHttpHeaders} from "http";

const app = express();
app.use(express.json());

interface RequestData {
    body: string;
    headers: IncomingHttpHeaders;
    url: string;
    method: string;
}

async function getKeyId(): Promise<string> {
    const response = await axios.get('https://common-sandbox.api.acubeapi.com/signature-public-key');
    return response.data.public_key;
}

async function verifyHttpSignature(data: RequestData): Promise<boolean> {
    const publicKey = await getKeyId(); // Ideally, cache or retrieve more efficiently
    try {
        jwt.verify(data.body, publicKey, {algorithms: ['HS256']});
        return true;
    } catch (error) {
        console.error(error);
        return false;
    }
}

app.post('/my_webhook', async (req: Request, res: Response) => {
    const requestData: RequestData = {
        body: req.body,
        headers: req.headers,
        url: req.originalUrl,
        method: req.method,
    };

    if (!await verifyHttpSignature(requestData)) {
        return res.status(401).send({message: 'Invalid http signature'});
    }

    res.send({message: 'Done'});
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

