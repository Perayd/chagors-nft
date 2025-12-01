// assumes window.ethereum, ethers v5
const provider = new ethers.providers.Web3Provider(window.ethereum);
await provider.send("eth_requestAccounts", []);
const signer = provider.getSigner();
const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);

// mint 1
const tx = await contract.mint(1, { value: ethers.utils.parseEther("0.05") });
await tx.wait();
