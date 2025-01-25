# EVE Frontier Bulk Online / Offline Script

A forge script that attempts to converge on a target state, either ONLINE or OFFLINE, by inspecting the on-chain state and issuing transactions to change the state. At the moment it only targets Smart Turrets although could easily be adapted to support SSUs and Smart Gates.

## Limitations

CCP have not implemented `IERC721Enumerable` so it's not possible to enumerate all Smart Deployables for the account, to get around this limitations we have a simple text file listing Smart Deployables in `./data/erc721deploybl__Owners.txt`. This can be obtained from the [World Explorer](https://explorer.mud.dev/garnet/worlds/0x7fe660995b0c59b6975d5d59973e2668af6bb9c5/explore?tableId=0x74626572633732316465706c6f79626c4f776e65727300000000000000000000&query=SELECT%2520%2522tokenId%2522%2520FROM%2520erc721deploybl__Owners%2520WHERE%2520%2522owner%2522%2520%253D%2520%270x9C3DD27Eb75076383269bd30C3ea6A33151D9f26%27%253B):

```sql
SELECT "tokenId" FROM erc721deploybl__Owners WHERE "owner" = '0x9C3DD27Eb75076383269bd30C3ea6A33151D9f26';
```

You can download a TXT file, the script will automatically ignore the heading.

```
tokenId
10074803998790193882231315991415676610785627093638131764268405350289244740380
12182460908268314085490207357963067193240039848346484187158411896144899073584
108699169505062491413390987205387773100354218669992298093306334401469889690374
49240198130190626126447286418625368499371258892696229807313310414687671817084
55849396101903733577249383504672870265144300175665843488854410094826026863578
89929449024255543384433009674520022221879999135939638123930124754981019555776
```

> [!IMPORTANT]
> Change the wallet ID to your public key / address.

## Prerequisites 

You will need to ensure you have [Setup your Tools](https://docs.evefrontier.com/Tools) before running this script.

### Environment

Configure your `.env` as follows:

```ini
# Stillness - 1st Closed Alpha
PRIVATE_KEY=[YOUR PRIVATE KEY]
PUBLIC_KEY=[YOUR PUBLIC KEY]
WORLD_ADDRESS=0x7fe660995b0c59b6975d5d59973e2668af6bb9c5
RPC_URL=https://rpc.garnetchain.com
CHAIN_ID=17069
```