import * as React from "react";

type Props = React.SVGProps<SVGSVGElement> & {
  title?: string;
};

export function GooglePlayIcon({ title = "Google Play", ...props }: Props) {
  return (
    <svg
      viewBox="0 0 512 512"
      width="1em"
      height="1em"
      fill="none"
      aria-hidden={props["aria-label"] ? undefined : true}
      role="img"
      {...props}
    >
      {title ? <title>{title}</title> : null}
      {/* Simple Google Play mark (triangle) */}
      <path
        d="M66 46c-6 7-10 16-10 27v366c0 11 4 20 10 27l224-221L66 46Z"
        fill="#00A0FF"
      />
      <path d="M312 269 290 291 68 509c10 8 23 9 37 1l252-144-45-97Z" fill="#EA4335" />
      <path d="M357 146 105 2c-14-8-27-7-37 1l222 218 67-75Z" fill="#34A853" />
      <path d="M456 243c0-12-6-23-17-29l-82-47-74 82 74 82 82-47c11-6 17-17 17-29Z" fill="#FBBC04" />
    </svg>
  );
}

