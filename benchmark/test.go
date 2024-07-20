package main
import ( "net/http")
func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("{}")) });
	http.ListenAndServe(":8082", nil);
}
