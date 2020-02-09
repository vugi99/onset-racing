import React from "react";
import { useSelector } from "react-redux";
import { IAppState } from "../redux/reducer";

export const Speedometer = () => {

    const playerSpeed = useSelector((appState: IAppState) => appState.speed);

    console.log("Player Speed : ", playerSpeed);

    return null;

}
