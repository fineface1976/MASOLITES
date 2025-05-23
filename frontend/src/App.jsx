import React, { useState } from 'react';
import { useFlutterwave } from 'flutterwave-react-v3';

export default function App() {
    const [email, setEmail] = useState('');
    const [upline, setUpline] = useState('');

    const config = {
        public_key: 'FLW_PUBLIC_KEY',
        tx_ref: `MASOL-${Date.now()}`,
        amount: 1000,
        currency: 'NGN',
        customer: { email },
        callback: (response) => {
            fetch('/register', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ email, uplineAddress: upline })
            });
        }
    };

    const handleFlutterwave = useFlutterwave(config);

    return (
        <div className="container">
            <h1>Join MASOLITES (₦1,000/year)</h1>
            <input type="email" placeholder="Email" onChange={(e) => setEmail(e.target.value)} />
            <input type="text" placeholder="Upline Address" onChange={(e) => setUpline(e.target.value)} />
            <button onClick={handleFlutterwave}>Pay & Register</button>
        </div>
    );
}
