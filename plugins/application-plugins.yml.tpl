store:
  plugins:
    enabled: true
    exit-on-error: true
    filters:
      utxo.unspent.save:
        - name: filter-address-utxos
          lang: mvel
          inline-script: |
            inputAddresses = ${ADDRESSES_ARRAY};
            
            ret = [];
            for (item : items) {
              if (inputAddresses.contains(item.ownerAddr)) {
                ret.add(item);
              }
            }
            return ret;

    event-handlers:
      EpochChangeEvent:
        - name: clear-tx-inputs
          lang: mvel
          script:
            file: /app/plugins/${YACI_STORE_DB_TYPE}-clear-tx-inputs.mvel

      AddressUtxoEvent:
      - name: sum-utxo-balance
        lang: mvel
        inline-script: |
          def writeToFile(text, filename) {
            import java.io.PrintWriter;
            import java.io.FileWriter;

            if (text == null) {
              println("No text to write!");
              return;
            }
            if (filename == null || filename == "") {
              println("No filename given!");
              return;
            }
            // This may still error if the path is unwritable, but at least you checked inputs.
            var writer = new PrintWriter(new FileWriter(filename, false));
            writer.println(text);
            writer.close();
          }
          def handle(event) {
            inputAddresses = ${ADDRESSES_ARRAY};
          
            foundAddresses = [];
            for (txio : event.txInputOutputs) {
              for (output : txio.outputs) {
                if (inputAddresses.contains(output.ownerAddr)) {
                  foundAddresses.add(output.ownerAddr);
                }
              }
            }
          
            // Remove duplicates (optional)
            uniqueAddresses = [];
            for (addr : foundAddresses) {
              if (!uniqueAddresses.contains(addr)) {
                uniqueAddresses.add(addr);
              }
            }
          
            if (uniqueAddresses.size() > 0) {
              var sql = "SELECT owner_addr, SUM(lovelace_amount) AS total FROM address_utxo GROUP BY owner_addr";
              var rows = jdbc.queryForList(sql);
              var sb = new StringBuilder();
              
              for (row : rows) {
                  sb.append("cardano_balance_")
                    .append(row.get("owner_addr"))
                    .append(" ")
                    .append(row.get("total"))
                    .append("\n");
              }
              
              writeToFile(sb.toString(), "/data/node-exporter/utxo_balances");

            }
          }
          handle(event);
