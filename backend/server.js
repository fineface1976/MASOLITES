const express = require('express');
const Flutterwave = require('flutterwave-node-v3');
const app = express();
const { Web3 } = require('web3');

// BSC Setup
const web3 = new Web3('https://bsc-dataseed.binance.org/');
const tokenABI = require('./MASOLTokenABI.json');
const tokenAddress = '0x...'; // Replace after deployment
const tokenContract = new web3.eth.Contract(tokenABI, tokenAddress);

// Flutterwave Setup
const flw = new Flutterwave(process.env.FLW_PUBLIC_KEY, process.env.FLW_SECRET_KEY);

// MLM Registration Endpoint
app.post('/register', async (req, res) => {
    const { email, uplineAddress } = req.body;
    
    // Charge ₦1,000 via Flutterwave
    const payment = await flw.Payment.charge({
        amount: 1000,
        currency: 'NGN',
        email,
        tx_ref: `MASOL-${Date.now()}`
    });

    // Call BSC Smart Contract
    const tx = tokenContract.methods.register(uplineAddress);
    const gas = await tx.estimateGas({ from: payment.customer.email });
    const signedTx = await web3.eth.accounts.signTransaction({
        to: tokenAddress,
        data: tx.encodeABI(),
        gas
    }, process.env.PRIVATE_KEY);

    await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    res.json({ success: true });
});

app.listen(3000, () => console.log('Backend running on BSC!'));
