package main

import (
	"fmt"

	"github.com/emirpasic/gods/sets/hashset"
	gods2 "github.com/emirpasic/gods/v2/lists/arraylist"
)

func main() {
	s := hashset.New()
	s.Add(1)
	s.Add(2)
	fmt.Println(s.Contains(2))

	l := gods2.New[int]()
	l.Add(10)
	fmt.Println(l.Size())
}
