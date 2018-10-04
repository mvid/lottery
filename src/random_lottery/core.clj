(ns random-lottery.core
  (:gen-class))

(defn -main
  "I don't do a whole lot ... yet."
  [& args]
  (println "Hello, World!")
  (let [web3j (org.web3j.protocol.Web3j/build (org.web3j.protocol.http.HttpService.))]
    (print web3j)))

