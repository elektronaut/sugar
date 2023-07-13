import React, { Component } from "react";
import { formatDate } from "../lib/dates";

interface RelativeTimeProps {
  time: Date | string;
}

interface RelativeTimeState {
  currentTime: Date;
}

export default class RelativeTime extends Component<
  RelativeTimeProps,
  RelativeTimeState
> {
  timerInterval: number;

  constructor(props: RelativeTimeProps) {
    super(props);
    this.state = { currentTime: new Date() };
  }

  time() {
    const time = this.props.time;
    return typeof time == "string" ? new Date(time) : time;
  }

  componentDidMount() {
    this.timerInterval = setInterval(() => {
      this.setState({ currentTime: new Date() });
    }, 15000);
  }

  componentWillUnmount() {
    clearInterval(this.timerInterval);
  }

  diff() {
    return Math.ceil((this.time() - this.state.currentTime) / 1000);
  }

  formattedDistance() {
    const absDiff = Math.abs(this.diff());

    if (absDiff > 60 * 60 * 24 * 14) {
      return this.timestamp();
    }

    const [value, unit] = this.labelledDistance();
    const absValue = Math.floor(value);

    let label = unit;
    if (absValue > 1) {
      label = `${label}s`;
    }

    let timeStr = `${absValue} ${this.label(label)}`;
    if (absDiff < 3) {
      return "now";
    }
    if (absDiff < 60) {
      timeStr = "a moment";
    }

    if (this.diff() < 0) {
      return `${timeStr} ago`;
    } else {
      return `in ${timeStr}`;
    }
  }

  label(key: string) {
    return {
      second: "second",
      seconds: "seconds",
      minute: "minute",
      minutes: "minutes",
      hour: "hour",
      hours: "hours",
      day: "day",
      days: "days",
      year: "year",
      years: "years"
    }[key];
  }

  labelledDistance() {
    const seconds = Math.abs(this.diff());
    const minutes = seconds / 60;
    const hours = minutes / 60;
    const days = hours / 24;
    const years = days / 365;

    if (years >= 1) {
      return [years, "year"];
    } else if (days >= 1) {
      return [days, "day"];
    } else if (hours >= 1) {
      return [hours, "hour"];
    } else if (minutes >= 1) {
      return [minutes, "minute"];
    } else {
      return [seconds, "second"];
    }
  }

  render() {
    return <React.Fragment>{this.formattedDistance()}</React.Fragment>;
  }

  timestamp() {
    return formatDate(this.time());
  }
}
