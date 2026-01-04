import { isEnvBrowser } from "./misc";

export async function fetchNui<T = any>(
    eventName: string,
    data?: any,
    mock?: { data: T; delay?: number }
): Promise<T> {
    if (isEnvBrowser()) {
        if (!mock) return await new Promise((resolve) => resolve);
        await new Promise((resolve) => setTimeout(resolve, mock!.delay));
        return mock.data;
    }

    const options = {
        method: "post",
        headers: {
            "Content-Type": "application/json; charset=UTF-8",
        },
        body: JSON.stringify(data),
    };

    const resourceName = (window as any).GetParentResourceName
        ? (window as any).GetParentResourceName()
        : "nui-frame-app";

    const resp = await fetch(`https://${resourceName}/${eventName}`, options);

    const respFormatted = await resp.json();

    return respFormatted;
}
