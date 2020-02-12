import React from "react";
import { useSelector } from "react-redux";
import { IAppState } from "../redux/reducer";

export const Decompte = () => {
    const decompteValue = useSelector((appState: IAppState) => appState.decompte);

    return decompteValue ? <div className="decompte">
        {decompteValue}
    </div> : null;
}
