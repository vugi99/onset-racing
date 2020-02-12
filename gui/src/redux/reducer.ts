import { createAction, AnyAction, createReducer } from "@reduxjs/toolkit";
import { wrapAction } from "../onset";

// Here I create an action that takes no argument
export const notifySpeed = createAction("NOTIFY_SPEED");

// I want this action to be available to Onset so I attach it globally
(window as any).NotifySpeed = wrapAction(notifySpeed)

// Here I declare the state of my whole application
// I only have one of course because this is only counting
export interface IAppState {
    speed: number;
    decompte?: number;
}

const initialState: IAppState = {
    speed: 0
};

// Here it is my reducer, his tasks is to merge the future state with
export const counterReducer = createReducer(initialState, {
    [notifySpeed.type]: (state, action) => ({ ...state, 
        speed: Math.abs(Number.parseFloat(action.payload)),
    })
});
