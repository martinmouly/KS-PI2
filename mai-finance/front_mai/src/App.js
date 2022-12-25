import React from "react";
//import ReactDOM from "react-dom/client";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Intro from "./pages/Intro.js";
import Layout from "./pages/Layout.js";
import NoPages from "./pages/NoPages.js";



export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Intro />} />
          <Route path="*" element={<NoPages />} />
        </Route>
      </Routes>
    </BrowserRouter>
  );
}




