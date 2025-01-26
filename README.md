# EVE Frontier Bulk Online / Offline Script

A forge script that attempts to converge `SmartDeployables` on a target state, either `ONLINE` or `OFFLINE`, it does this by inspecting the on-chain state and issuing only the required transactions to match this state. At the moment it only targets Smart Turrets although could easily be adapted to support SSUs and Smart Gates.

## Limitations

CCP have not implemented `IERC721Enumerable` so it's not possible to enumerate all Smart Deployables for the account, to get around this limitations we have a simple text file listing Smart Deployables in `./data/erc721deploybl__Owners.txt`. This can be obtained from the [World Explorer](https://explorer.mud.dev/garnet/worlds/0x7fe660995b0c59b6975d5d59973e2668af6bb9c5/explore?tableId=0x74626572633732316465706c6f79626c4f776e65727300000000000000000000&query=SELECT%2520%2522tokenId%2522%2520FROM%2520erc721deploybl__Owners%2520WHERE%2520%2522owner%2522%2520%253D%2520%270x9C3DD27Eb75076383269bd30C3ea6A33151D9f26%27%253B):

```sql
SELECT "tokenId" FROM erc721deploybl__Owners WHERE "owner" = '0x9C3DD27Eb75076383269bd30C3ea6A33151D9f26';
```

You can download a TXT file, the script will automatically ignore the heading.

```text
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

### Operating System Configuration

These instructions are adapted from CCP's [Setup your Tools](https://docs.evefrontier.com/Tools) document and must be performed in advance of running the commands below. They are necessary to install the required software to run the script.

#### Windows Users

We strongly recommend installing WSL, or using a separate virtual or physical machine to install Foundry.

> [!IMPORTANT]
> Foundry's Forge is not well supported on Windows, there are known issues running it in Git Bash / MINGW64, I strongly recommend [installing Windows Subsystem for Linux](https://learn.microsoft.com/en-us/windows/wsl/install) which uses virtualization to install Linux on Windows.

1. Open PowerShell or Windows Command Prompt in **administrator** mode, by right clicking the icon and selecting "Run as administrator".
2. Enter `wsl --install` from the **administrator** PowerShell or Windows Command Prompt, then restart your computer.
3. The default distribution is Ubuntu, this is typically the easiest distribution to use.

> [!TIP]
> [Windows Terminal](https://apps.microsoft.com/detail/9n0dx20hk701?hl=en-US&gl=US) is an excellent terminal emulator for Windows, it also autodetects WSL installations making it easier to launch WSL.

#### Mac Users

All of the packages below can be installed on Macs, however you may need to use alternative package manages such as `brew` to install the package.

### Tool Setup

#### Dependencies

Install `git` (version control software) and `curl` (command line web client):

```sh
sudo apt-get install git curl
```

#### Node Version Manager and Node

```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
source ~/.bashrc
nvm install 18
```

> [!TIP]
> If you are using a shell other than `bash` adjust the commands above to update your shell config as required.

#### PNPM

PNPM is a alternative to the NPM package management:

```sh
npm install -g pnpm@latest
```

#### Foundry

Foundry is a blockchain development toolchain:

```sh
curl -L https://foundry.paradigm.xyz | bash
. ~/.bashrc
foundryup
```

> [!TIP]
> If you are using a shell other than `bash` adjust the commands above to update your shell config as required.

#### Fetch the Repository

```sh
cd ~
git clone https://github.com/frontier-reapers/bulk-smart-deployables.git
```

## Environment

You will need two bits of information from your EVE Vault to be able to execute the script, I recommend you import your recovery phrase [into EVE Wallet](https://docs.evefrontier.com/EveVault/installation) in a Chromium-based web browser. You can also find this information from the Frontier client, if you have imported your wallet into the in-game Vault.

Once you have imported your wallet, you will need to find:

1. **Public Key** - this is the long number starting with `0x` in the top right hand corner of Account #1 in EVE Vault, you can click it and it will be copied to the clipboard. 
2. **Private Key** - click the three dots next to Account #1, then choose "View Private Key", enter your password then click "Copy Key".

You can add these two bits of information to the `.env` file using the template below and place it in the root of this repository, this file is ignored by Git.

```ini
# Stillness - 1st Closed Alpha
PRIVATE_KEY=[YOUR PRIVATE KEY]
PUBLIC_KEY=[YOUR PUBLIC KEY]
WORLD_ADDRESS=0x7fe660995b0c59b6975d5d59973e2668af6bb9c5
RPC_URL=https://rpc.garnetchain.com
CHAIN_ID=17069
```