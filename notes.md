# notes.md
Some development notes

## On the use of `curl`
Here's an example of creating an account using curl:

    curl -i -H "Content-Type: application/json" \
    -X POST \
    -d '{"username": "Mario", "password": "ilovepeach"}' \
    http://localhost:8080/account && echo ""

Here's an example of creating a session using curl:

    curl -i -H "Authorization: Basic TWFyaW86aWxvdmVwZWFjaA==" \
    -X POST \
    http://localhost:8080/session && echo ""

## On the use of `dd`
Here's an example of using dd to generate base64 strings:

    dd if=/dev/urandom bs=1 count=8 2>/dev/null | base64 --wrap 0 && echo ""
