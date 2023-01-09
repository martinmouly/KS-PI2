import './App.css'
import './index.css'
import Home from './Home';
import Borrow from './Borrow';
import Deleg from './Deleg';
import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";

export default function App () {
  return (
    
      <BrowserRouter>
      <Routes>
        <Route index element={<Home />} />
        <Route path="/borrow" element={<Borrow />}  />
        <Route path="/delegate" element={<Deleg />}  />
      </Routes>
      </BrowserRouter>
  );
}

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);