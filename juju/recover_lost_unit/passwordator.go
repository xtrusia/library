package main

import (
    "fmt"
    "os"
    "github.com/juju/utils"
)

const MIN_LEN = 18

func main() {

  if (len(os.Args) < 2) {
    fmt.Printf("Error: you need to specify the password!\n")
    return
  }

  if (len(os.Args[1]) < MIN_LEN) {
    fmt.Printf("Error:Password size must be >= %d chars\n", MIN_LEN)
    return
  }

  fmt.Println(utils.AgentPasswordHash(os.Args[1]))
}
