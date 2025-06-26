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

      BlockEvent:
      - name: write-utxo-balance-file
        lang: mvel
        script:
          file: /app/plugins/write-utxo-balance-file.mvel
