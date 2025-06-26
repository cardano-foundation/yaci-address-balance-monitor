store:
  plugins:
    enabled: true
    exit-on-error: true
    filters:
      utxo.unspent.save:
        - name: filter-address-utxos
          lang: mvel
          inline-script: |
            ret = [];
            for (item : items) {
              if (item.ownerAddr == '${ADDRESS}') {
                ret.add(item);
              }
            }
            return ret;

    post-actions:
      utxo.unspent.save:
        - name: post-action-address-utxos
          lang: mvel
          inline-script: |
            var sql = "DO $$\n" +
                      "BEGIN\n" +
                      "    DELETE FROM tx_input;\n" +
                      "EXCEPTION\n" +
                      "    WHEN others THEN\n" +
                      "        RAISE NOTICE 'Error ignored: %', SQLERRM;\n" +
                      "END;\n" +
                      "$$;";
            jdbc.update(sql);

    event-handlers:
      AddressUtxoEvent:
      - name: sum-utxo-balance
        lang: mvel
        inline-script: |
          def writeToFile(text, filename) {
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
            addresses = [];
            for (txio : event.txInputOutputs) {
              for (output : txio.outputs) {
                addresses.add(output.ownerAddr);
              }
            }

            if (addresses.contains('${ADDRESS}')) {
              var sql = "SELECT SUM(lovelace_amount) AS total FROM address_utxo";
              var rows = jdbc.queryForList(sql);
              for (row : rows) {
                System.out.println(row); // row is a Map<String,Object>
              }
            }
          }
          handle(event);
