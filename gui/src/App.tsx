import React from 'react';
import './App.css';
import { Provider } from 'react-redux';
import {store} from "./redux/store";
import { Speedometer } from './Speed/Speedometer';
import { Decompte } from './Decompte/DecompteValue';
import { Counter } from './Counter/Counter';

// This is the main part of the application that will run as soon as the cef is ready and javascript loaded
const App: React.FC = () => {
  return (
    <Provider store={store}>
      <Counter />
      <Decompte />
      <Speedometer />

      <div className="helpFooter">
        <>F1 - Help</> 
      </div>
    </Provider>
  );
}

export default App;
