package main

import (
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"flag"
	"fmt"
	"os"
)

var username string
var password string

var json_output bool

type json_data struct {
	Username string `json:"username"`
	Password string `json:"password"`
	RpcAuth  string `json:"rpcauth"`
}

func init() {
	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Usage: %s <username> [password]", os.Args[0])
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "Create login credentials for a JSON-RPC user")
		fmt.Fprintln(os.Stderr, "")
		fmt.Fprintln(os.Stderr, "arguments:")
		fmt.Fprintln(os.Stderr, "  username    the username for authentication")
		fmt.Fprintln(os.Stderr, "  password    leave empty to generate a random password")
		fmt.Fprintln(os.Stderr, "")
	}

	flag.Parse()

	username = flag.Arg(0)
	password = flag.Arg(1)
}

func main() {
	fmt.Fprintln(os.Stderr, "provided username:")
	fmt.Fprintln(os.Stderr, username)
	fmt.Fprintln(os.Stderr, "provided password:")
	fmt.Fprintln(os.Stderr, password)

	if username == "" {
		flag.Usage()
		os.Exit(10)
	}

	if password == "" {
		password = generate_password()
	}

	salt := generate_salt(16)
	password_hmac := password_to_hmac(salt, password)

	rpc_auth := fmt.Sprintf("%s:%s$%s", username, salt, password_hmac)

	fmt.Fprintln(os.Stderr, "")
	fmt.Fprintln(os.Stderr, "rpcauth:")
	fmt.Fprintln(os.Stderr, "-------")
	fmt.Fprintf(os.Stdout, "%s", rpc_auth)
	fmt.Fprintln(os.Stdout, "")
	fmt.Fprintln(os.Stderr, "^^^^^^^")
	fmt.Fprintln(os.Stderr, "")

	fmt.Fprintf(os.Stderr, "%s", password)
	fmt.Fprintln(os.Stderr, "")

	os.Exit(0)
}

func generate_password() string {
	bytes := make([]byte, 32)
	rand.Read(bytes)

	return base64.RawURLEncoding.EncodeToString(bytes)
}

func generate_salt(size uint8) string {
	key := make([]byte, size)
	rand.Read(key)

	return hex.EncodeToString(key)
}

func password_to_hmac(salt string, password string) string {
	mac := hmac.New(sha256.New, []byte(salt))
	mac.Write([]byte(password))

	return hex.EncodeToString(mac.Sum(nil))
}
