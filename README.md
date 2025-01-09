# Examples of an A-CUBE webhook server written in Typescript and bash scripts to use A-CUBE APIs

## A-CUBE webhook server
This project is a sample implementation of a webhook that [checks the validity of A-Cube signature](https://docs.acubeapi.com/documentation/common/http-signature/#python).

To run it, first install dependencies with
```shell
npm install
```
Compile Typescript code with
```shell
npx tsc
```
Then start the server with
```shell
npm start
```
The server should now be running on port 3000.

## Sample scripts
### Bash
In the [/scripts](/scripts) folder you can find some bash scripts to connect to A-CUBE APIs.
To use them copy [.env](.env) file into `.env.local` and change the values as needed.
To run most of these scripts you need to install [jq](https://jqlang.github.io/jq/).

### Ruby
There is also a [Ruby example](/scripts/script.rb) that you can run with:
```shell
ruby ./scripts/script.rb <a_fiscal_id>
```

### Python
You can find a [Python example](/scripts/script.py) as well. Run it with:
```shell
python3 ./scripts/script.py <a_fiscal_id>
```
